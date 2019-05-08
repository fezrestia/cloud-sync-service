import * as React from "react";
import { render } from "react-dom";

import App from "./components/App";

render(
  <App message="WORLD" />,
  document.getElementById("root"),
);

import { sum } from "./components/Module";

console.log(sum(1, 2).toString());
