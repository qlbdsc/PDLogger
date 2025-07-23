package com.sdbi.j2se;

import org.apache.commons.cli.*;
import org.eclipse.jdt.core.*;
import org.eclipse.jdt.core.dom.*;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;
import java.util.Random;
import java.text.ParseException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.io.File;
import java.util.Optional;

public class method_scope {
    public static void main(String[] args) throws Exception {
        org.apache.commons.cli.Options options = new Options();

        Option inputOption = new Option("j", "javafile", true, "input the java file path");
        inputOption.setRequired(true);
        options.addOption(inputOption);

        Option methodOption = new Option("m", "methodname", true, "input the method name");
        methodOption.setRequired(true);
        options.addOption(methodOption);

        DefaultParser basicParser = new DefaultParser();
        CommandLine commandLine;

        commandLine = basicParser.parse(options, args);

        String javafile = commandLine.getOptionValue("javafile");
        String targetMethodSignature = commandLine.getOptionValue("methodname");

        String source = Files.readString(Paths.get(javafile), StandardCharsets.UTF_8);

        // Set up the ASTParser
        ASTParser astParser = ASTParser.newParser(AST.JLS10); // Use Java 17 syntax
        astParser.setKind(ASTParser.K_COMPILATION_UNIT);

        astParser.setUnitName(javafile);
        astParser.setSource(source.toCharArray());
        astParser.setResolveBindings(true);

        CompilationUnit cu = (CompilationUnit) astParser.createAST(null);

        String targetMethodName = targetMethodSignature;

        // Traverse the AST and extract the start and end lines of the specified method
        cu.accept(new ASTVisitor() {
            @Override
            public boolean visit(MethodDeclaration node) {
                String methodName = node.getName().getIdentifier();
                if (methodName.equals(targetMethodName)) {
                    int startLine = cu.getLineNumber(node.getStartPosition());
                    int endLine = cu.getLineNumber(node.getStartPosition() + node.getLength());
                    System.out.println(startLine + " " + endLine);
                }
                return super.visit(node);
            }
        });
    }
}

