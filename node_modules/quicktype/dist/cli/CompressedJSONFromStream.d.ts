/// <reference types="node" />
import * as stream from "stream";
import { CompressedJSON, Value } from "../quicktype-core/input/CompressedJSON";
export declare class CompressedJSONFromStream extends CompressedJSON<stream.Readable> {
    parse(readStream: stream.Readable): Promise<Value>;
    protected handleStartNumber: () => void;
    protected handleNumberChunk: (s: string) => void;
    protected handleEndNumber(): void;
    protected handleTrueValue(): void;
    protected handleFalseValue(): void;
}
