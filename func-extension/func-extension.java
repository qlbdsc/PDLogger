package com.sdbi.j2se;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.body.*;
import com.github.javaparser.ast.expr.*;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;
import com.github.javaparser.resolution.declarations.ResolvedMethodDeclaration;
import com.github.javaparser.symbolsolver.JavaSymbolSolver;
import com.github.javaparser.resolution.model.*;
import com.github.javaparser.resolution.TypeSolver;
import com.github.javaparser.symbolsolver.resolution.typesolvers.*;
import com.github.javaparser.ast.ImportDeclaration;

import java.io.File;
import java.nio.file.Path;
import java.util.*;

public class MethodClassifier {

    /** Entry point: args[0] = source code root directory, args[1] = .java file path to analyze */
    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println("Usage: MethodClassifier <srcRoot> <JavaFile>");
            System.exit(1);
        }
        Path srcRoot = Path.of(args[0]);
        File javaFile = new File(args[1]);

        /* ---------- ① Configure Symbol Resolution ---------- */
        TypeSolver reflection = new ReflectionTypeSolver();
        TypeSolver sourceSolver = new JavaParserTypeSolver(srcRoot);
        CombinedTypeSolver solver = new CombinedTypeSolver(reflection, sourceSolver);
        StaticJavaParser.getConfiguration().setSymbolResolver(new JavaSymbolSolver(solver));

        /* ---------- ② Parse and Classify ---------- */
        CompilationUnit cu = StaticJavaParser.parse(javaFile);
        cu.findAll(ClassOrInterfaceDeclaration.class).forEach(clazz -> {
            String clazzName = clazz.getNameAsString();
            List<String> superChain = getSuperChain(clazz);

            // System.out.printf("===== CLASS %s =====%n", clazzName);

            /* 2-A  Declared Member Methods and Inherited Methods (Signatures) */
            clazz.getMethods().forEach(m -> {
                System.out.printf("Member(%s)  %s()%n",
                        m.getAccessSpecifier(), m.getNameAsString());
            });
            superChain.forEach(sc -> System.out.printf("  (inherits from %s)%n", sc));

            /* 2-B  Traverse Method Call Expressions and Lambdas within Method Bodies */
            clazz.getMethods().forEach(hostMethod ->
                    hostMethod.accept(new VoidVisitorAdapter<Void>() {
                        @Override
                        public void visit(MethodCallExpr call, Void arg) {
                            super.visit(call, arg);
                            classifyCall(call, clazzName, superChain);
                        }
                        @Override
                        public void visit(LambdaExpr le, Void arg) {
                            super.visit(le, arg);
                            System.out.printf("Lambda     in %s()  →  parameters=%s%n",
                                    hostMethod.getName(), le.getParameters());
                        }
                    }, null));
        });

        /* 2-C  Collect Static Imports */
        cu.getImports().stream().filter(ImportDeclaration::isStatic).forEach(impt -> {
            System.out.printf("Static-Import  %s%n", impt.getName());
        });
    }

    /* ----------- Utility Methods ----------- */

    /** Get the inheritance chain starting from the current class (excluding java.lang.Object) */
    private static List<String> getSuperChain(ClassOrInterfaceDeclaration clazz) {
        List<String> chain = new ArrayList<>();
        clazz.getExtendedTypes().forEach(et -> chain.add(et.getNameAsString()));
        return chain;
    }

    /** Print a classified method call */
    private static void classifyCall(MethodCallExpr call,
                                     String self, List<String> supers)  {
        try {
            ResolvedMethodDeclaration rmd = call.resolve();
            String declType = rmd.declaringType().getQualifiedName();

            String category;
            if (declType.equals(self)) {
                category = "Member-Call";
            } else if (supers.contains(rmd.declaringType().getClassName())) {
                category = "Inherited-Call";
            } else if (rmd.isStatic() && (declType.equals(self)
                    || supers.contains(rmd.declaringType().getClassName()))) {
                category = "StaticImport(Self/Super)";
            } else {
                return;         // Ignore third-party calls
            }
            System.out.printf("%-17s %s()%n", category, rmd.getName());
        } catch (Exception ignore) { /* parse failed */ }
    }
}

