import os
import subprocess
import argparse


parser = argparse.ArgumentParser(description="Run Joern analysis on a Java file.")
parser.add_argument("cpg_path", type=str, help="Path to the Java file for analysis.")
args = parser.parse_args()


cpg_path = args.cpg_path

joern_script = f"""
val cpgPath = "{cpg_path}"
importCode(cpgPath,"java")
val result = cpg.call.map(c => (c.id, c.methodFullName, c.method.id, c.callee.id.toList, c.lineNumber)).toList
println("callgraph:")
result.foreach(println) 
"""


with open("temp.sc", "w") as f:
    f.write(joern_script)


subprocess.run(["joern", "--script", "temp.sc"])


os.remove("temp.sc")




