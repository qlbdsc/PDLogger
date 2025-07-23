package blockid.blockid;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.stmt.ForStmt;
import com.github.javaparser.ast.stmt.IfStmt;
import com.github.javaparser.ast.stmt.TryStmt;
import com.github.javaparser.ast.stmt.WhileStmt;

public class App {

    public static void main(String[] args) throws IOException {
        Options options = new Options();

        Option path = new Option("p", "path", true, "input java file path");
        path.setRequired(true);
        options.addOption(path);
        DefaultParser basicParser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        CommandLine cmd;
        try {
            cmd = basicParser.parse(options, args);
        } catch (Exception e) {
            System.out.println(e.getMessage());
            formatter.printHelp("utility-name", options);
            System.exit(1);
            return;
        }

        String filePath = cmd.getOptionValue("path");
        // Create a File object pointing to the Java file to be parsed
        File file = new File(filePath);
        // Use JavaParser to parse the Java file
        CompilationUnit cu = StaticJavaParser.parse(file);

        AtomicInteger counter1 = new AtomicInteger(0); // IfStmt counter
        AtomicInteger counter2 = new AtomicInteger(0); // TryStmt counter
        AtomicInteger counter3 = new AtomicInteger(0); // Loop counter
        AtomicInteger counter4 = new AtomicInteger(0); // MethodDeclaration counter

        cu.findAll(IfStmt.class).forEach(ifStmt -> {
            counter1.incrementAndGet();

            int startLine = ifStmt.getBegin().map(pos -> pos.line).orElse(-1);    
            int endLine = ifStmt.getEnd().map(pos -> pos.line).orElse(-1);

            try {
                List<String> lines = Files.readAllLines(Paths.get(filePath));
                addCommentToLine(lines, startLine, "//This is start of Branching Block" + counter1.get());
                addCommentToLine(lines, endLine, "//This is end of Branching Block" + counter1.get());
                Files.write(Paths.get(filePath), lines);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        cu.findAll(TryStmt.class).forEach(TryStmt -> {
            counter2.incrementAndGet();

            int startLine = TryStmt.getBegin().map(pos -> pos.line).orElse(-1);    
            int endLine = TryStmt.getEnd().map(pos -> pos.line).orElse(-1);

            try {
                List<String> lines = Files.readAllLines(Paths.get(filePath));
                addCommentToLine(lines, startLine, "//This is start of Try-Catch Block" + counter2.get());
                addCommentToLine(lines, endLine, "//This is end of Try-Catch Block" + counter2.get());
                Files.write(Paths.get(filePath), lines);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        cu.findAll(ForStmt.class).forEach(ForStmt -> {
            counter3.incrementAndGet();

            int startLine = ForStmt.getBegin().map(pos -> pos.line).orElse(-1);    
            int endLine = ForStmt.getEnd().map(pos -> pos.line).orElse(-1);

            try {
                List<String> lines = Files.readAllLines(Paths.get(filePath));
                addCommentToLine(lines, startLine, "//This is start of Looping Block" + counter3.get());
                addCommentToLine(lines, endLine, "//This is end of Looping Block" + counter3.get());
                Files.write(Paths.get(filePath), lines);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        cu.findAll(WhileStmt.class).forEach(WhileStmt -> {
            counter3.incrementAndGet();

            int startLine = WhileStmt.getBegin().map(pos -> pos.line).orElse(-1);    
            int endLine = WhileStmt.getEnd().map(pos -> pos.line).orElse(-1);

            try {
                List<String> lines = Files.readAllLines(Paths.get(filePath));
                addCommentToLine(lines, startLine, "//This is start of Looping Block" + counter3.get());
                addCommentToLine(lines, endLine, "//This is end of Looping Block" + counter3.get());
                Files.write(Paths.get(filePath), lines);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        cu.findAll(MethodDeclaration.class).forEach(MethodDeclaration -> {
            counter4.incrementAndGet();

            int startLine = MethodDeclaration.getBegin().map(pos -> pos.line).orElse(-1);    
            int endLine = MethodDeclaration.getEnd().map(pos -> pos.line).orElse(-1);

            try {
                List<String> lines = Files.readAllLines(Paths.get(filePath));
                addCommentToLine(lines, startLine, "//This is start of Method Declaration Block" + counter4.get());
                addCommentToLine(lines, endLine, "//This is end of Method Declaration Block" + counter4.get());
                Files.write(Paths.get(filePath), lines);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        System.out.println(counter1.get());
        System.out.println(counter2.get());
        System.out.println(counter3.get());
        System.out.println(counter4.get());
    }

    private static void addCommentToLine(List<String> lines, int lineNumber, String commentText) {
        if (lineNumber > 0 && lineNumber <= lines.size()) {
            String line = lines.get(lineNumber - 1);
            lines.set(lineNumber - 1, line + commentText);
        } else {
            System.out.println("Line number out of range");
        }
    }
}

