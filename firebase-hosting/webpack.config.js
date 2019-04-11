const ENV = "development";
//const ENV = "production";

const isDebug = ENV === "development";

const path = require('path')

module.exports = {
    mode: ENV,

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
            },
            {
                test: /\.css$/, // ext = .css
                use: [ // will apply from end to top
                    {
                        loader: "style-loader",
                    },
                    {
                        loader: "css-loader",
                        options: {
                            url: false, // Ignore url() method in .scss
                            sourceMap: isDebug,
                        },
                    },
                ],
            },
            {
                test: /\.scss$/, // ext = .scss
                use: [ // will apply from end to top
                    {
                        loader: "style-loader",
                    },
                    {
                        loader: "css-loader",
                        options: {
                            url: false, // Ignore url() method in .scss
                            sourceMap: isDebug,

                            // 0 : No loader (default)
                            // 1 : postcss-loader
                            // 2 : postcss-loader, sass-loader
                            importLoaders: 2,
                        },
                    },
                    {
                        loader: "sass-loader",
                        options: {
                            sourceMap: isDebug,
                        },
                    },
                ],
            },
        ],
    },

    resolve: {
        extensions: [".js", ".ts"],
    },

};

