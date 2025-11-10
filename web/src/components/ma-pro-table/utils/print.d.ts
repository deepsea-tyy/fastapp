declare class Print {
    dom: any;
    options: {
        noPrint: any;
    };
    constructor(dom: any, options?: {});
    init(): void;
    extend(obj: any, obj2: any): any;
    getStyle(): string;
    getHtml(): any;
    writeIframe(content: any): void;
    toPrint(frameWindow: any): void;
    isDOM(obj: any): boolean;
}
export default Print;
