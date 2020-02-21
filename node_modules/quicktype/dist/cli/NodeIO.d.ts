/// <reference types="node" />
import { Readable } from "stream";
import { JSONSchemaStore, JSONSchema } from "../quicktype-core";
export declare function readableFromFileOrURL(fileOrURL: string, httpHeaders?: string[]): Promise<Readable>;
export declare function readFromFileOrURL(fileOrURL: string, httpHeaders?: string[]): Promise<string>;
export declare class FetchingJSONSchemaStore extends JSONSchemaStore {
    private readonly _httpHeaders?;
    constructor(_httpHeaders?: string[] | undefined);
    fetch(address: string): Promise<JSONSchema | undefined>;
}
