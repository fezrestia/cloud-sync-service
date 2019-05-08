import Button from "antd/lib/button";
import React from "react";

import "antd/lib/button/style/css";

interface IAppProps {
  message: string;
}

export default function({ message }: IAppProps) {
  return (
    <div>
      <h1>Hello {message}</h1>;
      <Button type="primary">Test</Button>
    </div>
  );
}
