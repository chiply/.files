I have three files: index.html, style.css, and script.js. Currently I can open index.html (which incorporates the other two files) and it renders in my web browser. I want to switch to using typescript to develop this project, and I want to do so as quickly as possible. Please guide me through how to quickly install the interpreters / compilers / or runtimes I need to install to make this easy.

Step 1: Install Node.js and npm
Node.js is an open-source, cross-platform JavaScript runtime environment that allows you to run JavaScript on your server or your local computer. Npm stands for node package manager. You will use npm to manage your server-side dependencies.

You can download Node.js directly from the official website: https://nodejs.org/en/download/.

Step 2: Install TypeScript
After installing Node.js and npm, open a terminal and run the following command to install TypeScript:

```
npm install -g typescript
```

The `-g` flag means you're installing TypeScript globally, so you can use it in any project from the terminal.

Step 3: Install a TypeScript loader (optional)
If you're using a module bundler like webpack you'll need to install a TypeScript loader. For webpack, you can use ts-loader. To install, run the following command:

```
npm install --save-dev typescript ts-loader
```

Step 4: Create a tsconfig.json file
In the root directory of your project, create a new file named tsconfig.json. This file specifies the root files and the compiler options required to compile the project. A simple example can be:

```json
{
  "compilerOptions": {
    "outDir": "./dist/",
    "sourceMap": true,
    "noImplicitAny": true,
    "module": "commonjs",
    "target": "es6",
    "jsx": "react"
  },
  "include": ["./src/**/*"]
}
```

You should modify this configuration to suit your specific needs.

Step 5: Rename your .js files to .ts
Lastly, rename your .js files to .ts (For instance, rename script.js to script.ts). If your .js files utilize JSX (like in React), rename them to .tsx.

Now you can use TypeScript instead of JavaScript. You just need to write TypeScript code and then compile it down to JavaScript with the tsc command. The TypeScript compiler will report errors if it finds something wrong with your TypeScript code.

Note: You might want to install a source map explorer to check how your TypeScript code is being translated into JavaScript. Also, consider setting up linting and formatting tools for a smoother development experience (like TSLint and Prettier).
