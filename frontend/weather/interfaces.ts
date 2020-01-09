import { TaggedSensor, TaggedSensorReading } from "farmbot";

export interface Props {
    sensors: TaggedSensor[];
    sensorReadings: TaggedSensorReading[];
}