const {
  configPaths,
  CracoAliasPlugin,
} = require("react-app-rewire-alias/lib/aliasDangerous");

const aliasMap = configPaths("./tsconfig.paths.json"); // or jsconfig.paths.json

module.exports = {
  plugins: [
    {
      plugin: CracoAliasPlugin,
      options: { alias: aliasMap },
    },
  ],
};
