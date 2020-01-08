import * as React from "react";
import { connect } from "react-redux";
//import { Props } from "./interfaces";

import { Page } from "../ui";

export class RawWeather extends React.Component<{}, {}> {

  render() {
    return <Page className="tools-page">
        <h1>Weather</h1>
    </Page>;
  }
}

export const Weather = connect(null)(RawWeather);
