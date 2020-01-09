import * as React from "react";
import { connect } from "react-redux";
import { mapStateToProps } from "./state_to_props";

import { TaggedSensor, TaggedSensorReading } from "farmbot";

interface Props {
    sensors: TaggedSensor[];
    sensorReadings: TaggedSensorReading[];
}

//import { Props } from "./interfaces";

import { Col, Page } from "../ui";

export class RawWeather extends React.Component<Props, {}> {
    render() {
        console.log("====================================");
        console.log(this.props);
        console.log("====================================");
        return (
            <Page className="weather-page">
                <Col xs={12} sm={12}>
                    <h1>Weather</h1>
                </Col>
            </Page>
        );
    }
}

export const Weather = connect(mapStateToProps)(RawWeather);
