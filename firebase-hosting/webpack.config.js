const path = require('path')

module.exports = {
    mode: "development",
//    mode: "production",

    entry: path.resolve(__dirname, "src/entry.ts"),

    output: {
        path: path.resolve(__dirname, "public"),
        filename: "entry.js",
    },

    module: {
        rules: [
            {
                test: /\.ts$/, // ext = .ts
                use: "ts-loader", // compile .ts
            }
        ]
    },

    resolve: {
        extensions: [".ts"] // Resolve .ts extension for import.
    },

};

