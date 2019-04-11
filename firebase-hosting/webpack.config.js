const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin"); // Extract CSS from JS.
const OptimizeCssAssetsWebpackPlugin = require("optimize-css-assets-webpack-plugin"); // Compress CSS.
const TerserWebpackPlugin = require("terser-webpack-plugin"); // Compress JS.

module.exports = (env, argv) => {
    // Environment.
    isDebug = argv.mode === "development";

    return {
        entry: path.resolve(__dirname, "src/entry.ts"),
        output: {
            path: path.resolve(__dirname, "public"),
            filename: "entry.js",
        },

        // Override optimization options.
        optimization: {
            minimizer: [
                new TerserWebpackPlugin({}),
                new OptimizeCssAssetsWebpackPlugin({}),
            ],
        },

        module: {
            rules: [
                // TypeScript.
                {
                    test: /\.ts$/, // ext = .ts
                    use: "ts-loader", // compile .ts
                },

                // CSS/SCSS/SASS.
                {
                    test: /\.(c|sc|sa)ss$/, // ext = .css/.scss/.sass
                    use: [ // will apply from end to top
                        {
                            loader: MiniCssExtractPlugin.loader,
                        },
                        {
                            loader: "css-loader",
                            options: {
                                url: false, // Ignore url() method in .scss

                                // 0 : No loader (default)
                                // 1 : postcss-loader
                                // 2 : postcss-loader, sass-loader
                                importLoaders: 2,
                            },
                        },
                        {
                            loader: "sass-loader",
                        },
                    ],
                },
            ],
        },

        resolve: {
            extensions: [".js", ".ts"],
        },

        plugins: [
            new MiniCssExtractPlugin( {
                filename: "entry.css",
            } ),
        ],

        devtool: 'inline-source-map',

    }; // return
};
