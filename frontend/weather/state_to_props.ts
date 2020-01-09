import { uniq } from "lodash";
//import { Everything } from "../interfaces";
import {
    selectAllSensors,
    selectAllSensorReadings
} from "../resources/selectors";
import { Everything } from "../interfaces";
import { TaggedSensor, TaggedSensorReading } from "farmbot";

interface Props {
    sensors: TaggedSensor[];
    sensorReadings: TaggedSensorReading[];
}

export function mapStateToProps(props: Everything): Props {
    return {
        sensors: uniq(selectAllSensors(props.resources.index)),
        sensorReadings: selectAllSensorReadings(props.resources.index)
    };
}
