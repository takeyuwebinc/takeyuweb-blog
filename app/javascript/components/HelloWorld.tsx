import React from "react";

interface Props {
  greeting: string;
}

const HelloWorld: React.SFC<Props> = props => {
  return <React.Fragment>Greeting: {props.greeting}</React.Fragment>;
};

export default HelloWorld;
