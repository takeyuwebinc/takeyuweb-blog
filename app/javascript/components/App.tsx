import React from "react";

import { BrowserRouter, Switch, Route } from "react-router-dom";

import HelloWorld from "./HelloWorld";

interface Props {}

const App: React.SFC<Props> = props => {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/" render={() => "Home!"} />
        <Route path="/hello" render={() => <HelloWorld greeting="Friend" />} />
      </Switch>
    </BrowserRouter>
  );
};

export default App;
