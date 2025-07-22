package com.sdbi.j2se;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.expr.*;
import com.github.javaparser.ast.stmt.ExpressionStmt;
import com.github.javaparser.ast.stmt.Statement;
import com.github.javaparser.ast.stmt.ThrowStmt;
import com.github.javaparser.ast.NodeList;

import java.io.File;
import java.nio.file.Path;
import java.util.*;

public class ThrowArgResolver {

    public static void main(String[] args) throws Exception {

        if (args.length == 0) {
            System.err.println("Usage: java … ThrowArgResolver <Java source file path>");
            System.exit(1);
        }

        Path filePath = Path.of(args[0]).toAbsolutePath();

        // Path filePath = (args.length == 0)
        //          ? Path.of("/Users/scduan/Desktop/SCLogger/callgraph_file_selection/1twicetest/A.txt")   // ← Change to your own test file
        //          : Path.of(args[0]).toAbsolutePath();

        CompilationUnit cu = StaticJavaParser.parse(new File(filePath.toString()));

        cu.findAll(MethodDeclaration.class).forEach(method -> {
            if (method.getBody().isEmpty()) return;

            Map<String, String> latestDefs = new HashMap<>();

            List<Statement> stmts = new ArrayList<>();
            stmts.addAll(method.getBody().get().findAll(ExpressionStmt.class));
            stmts.addAll(method.getBody().get().findAll(ThrowStmt.class));
            stmts.sort(Comparator.comparing(
                    s -> s.getRange().map(r -> r.begin.line).orElse(Integer.MAX_VALUE)
            ));

            for (Statement stmt : stmts) {

                /* A. Track the latest variable assignments */
                if (stmt.isExpressionStmt()) {
                    Expression expr = stmt.asExpressionStmt().getExpression();

                    if (expr instanceof VariableDeclarationExpr vde) {
                        vde.getVariables().forEach(vd ->
                                vd.getInitializer().ifPresent(init ->
                                        latestDefs.put(vd.getNameAsString(), init.toString())));
                    }
                    if (expr instanceof AssignExpr assign && assign.getTarget().isNameExpr()) {
                        latestDefs.put(assign.getTarget().asNameExpr().getNameAsString(),
                                assign.getValue().toString());
                    }
                }

                /* B. Handle `throw` statements */
                if (stmt.isThrowStmt()) {
                    ThrowStmt ts = stmt.asThrowStmt();
                    Expression ex = ts.getExpression();
                    if (ex instanceof ObjectCreationExpr oce) {
                        handleArgs(oce.getArguments(), latestDefs);
                    }
                }

                /* C. Handle `fail` / `failIf` method calls */
                if (stmt.isExpressionStmt()) {
                    Expression expr = stmt.asExpressionStmt().getExpression();
                    if (expr.isMethodCallExpr()) {
                        MethodCallExpr call = expr.asMethodCallExpr();
                        String name = call.getNameAsString().toLowerCase();
                        if (name.equals("fail") || name.equals("failif")) {
                            NodeList<Expression> argsList = call.getArguments();
                            if (!argsList.isEmpty()) {
                                int msgIdx = (name.equals("failif") && argsList.size() > 1) ? 1 : 0;
                                String res = resolveExpr(argsList.get(msgIdx), latestDefs);
                                System.out.println(res);
                            }
                        }
                    }
                }
            }
        });
    }

    /* Handle constructor/method arguments */
    private static void handleArgs(NodeList<Expression> args, Map<String, String> defs) {
        for (Expression arg : args) {
            System.out.println(resolveExpr(arg, defs));
        }
    }

    /* Recursively resolve expression → string */
    private static String resolveExpr(Expression expr, Map<String, String> defs) {

        /* 1) Literal string */
        if (expr.isStringLiteralExpr()) {
            return expr.asStringLiteralExpr().asString();
        }

        /* 2) Variable reference */
        if (expr.isNameExpr()) {
            String var = expr.asNameExpr().getNameAsString();
            return stripQuotes(defs.getOrDefault(var, var));
        }

        /* 3) Concatenation */
        if (expr.isBinaryExpr()) {
            BinaryExpr be = expr.asBinaryExpr();
            if (be.getOperator() == BinaryExpr.Operator.PLUS) {
                return resolveExpr(be.getLeft(), defs) + resolveExpr(be.getRight(), defs);
            }
        }

        /* 4) String.format(...) — extract all arguments */
        if (expr.isMethodCallExpr()) {
            MethodCallExpr mce = expr.asMethodCallExpr();
            if ("format".equals(mce.getNameAsString())
                && !mce.getArguments().isEmpty()
                && isStringFormatCall(mce)) {

                List<String> parts = new ArrayList<>();
                for (Expression arg : mce.getArguments()) {
                    parts.add(resolveExpr(arg, defs));
                }
                return String.join(", ", parts);
            }
        }

        /* 5) Other cases */
        return expr.toString();
    }

    /** Check whether a method call is String.format(...) */
    private static boolean isStringFormatCall(MethodCallExpr mce) {
        return mce.getScope()
                  .map(sc -> sc.toString().endsWith("String"))
                  .orElse(true);   // Default to true if no scope, compatible with static import
    }

    private static String stripQuotes(String s) {
        return (s != null && s.length() >= 2 && s.startsWith("\"") && s.endsWith("\""))
                ? s.substring(1, s.length() - 1)
                : s;
    }
}

