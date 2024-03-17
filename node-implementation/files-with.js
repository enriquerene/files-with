#!/usr/bin/env node
import { exec } from "child_process";
import yargs from "yargs/yargs";
import { hideBin } from "yargs/helpers";
import chalk from "chalk";

const argv = yargs(hideBin(process.argv))
  .usage(
    "Usage: node $0 <regex_pattern> [<directory>[ <grep_around_lines>[ ...]]]"
  )
  .example(
    'node $0 "pattern" .',
    'Search for "pattern" in all files under the current directory.'
  )
  .option("type", {
    alias: "t",
    describe: "File extension to filter by",
    type: "string",
  })
  .option("lines", {
    alias: "l",
    describe: "Number of context lines around matches",
    default: 0,
    type: "number",
  })
  .help().argv;

const pattern = argv._[0];
const directories = argv._.slice(1) || ["."];

if (!pattern) {
  console.error("No regex pattern provided. Use --help for usage information.");
  process.exit(1);
}

const searchFiles = (pattern, directories, type, lines) => {
  directories.forEach((dir) => {
    const findCommand = `find ${dir} -type f ${
      type ? `-name "*.${type}"` : ""
    }`;
    exec(findCommand, (err, stdout, stderr) => {
      if (err || stderr) {
        console.error(`Error executing find command: ${err || stderr}`);
        return;
      }

      const files = stdout.split("\n").filter((f) => f);
      files.forEach((file) => {
        const grepCommand = `grep -l "${pattern}" "${file}"`;
        exec(grepCommand, (grepErr, grepStdout, grepStderr) => {
          if (grepErr || grepStderr) return;

          if (lines > 0) {
            const grepContextCommand = `grep -C ${lines} --color=auto "${pattern}" "${file}"`;
            exec(
              grepContextCommand,
              (contextErr, contextStdout, contextStderr) => {
                if (contextErr || contextStderr) return;

                console.log(
                  chalk.yellow(
                    "----------------------------------------------------"
                  )
                );
                console.log(`Pattern found: '${pattern}' in File: ${file}`);
                console.log(
                  chalk.yellow(
                    "----------------------------------------------------"
                  )
                );
                console.log(contextStdout);
              }
            );
          } else {
            console.log(file);
          }
        });
      });
    });
  });
};

searchFiles(pattern, directories, argv.type, argv.lines);
