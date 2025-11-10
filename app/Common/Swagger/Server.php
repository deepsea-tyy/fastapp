<?php

declare(strict_types=1);


namespace App\Common\Swagger;

use Hyperf\Swagger\Annotation as OA;

#[OA\OpenApi(
    openapi: '3.0.0',
    info: new OA\Info(
        version: '3.0.0',
        title: 'fastapp',
        termsOfService: 'https://t.me/deepsea159',
        contact: new OA\Contact(name: 'Deepsea', url: 'https://t.me/deepsea159'),
    ),
    servers: [
        new OA\Server(
            url: 'http://127.0.0.1:9501',
            description: '本地服务'
        ),
    ],
    externalDocs: new OA\ExternalDocumentation(description: '开发文档', url: 'https://t.me/deepsea159')
)]
#[OA\SecurityScheme(
    securityScheme: 'Bearer',
    type: 'http',
    name: 'Authorization',
    bearerFormat: 'JWT',
    scheme: 'bearer'
)]
#[OA\SecurityScheme(
    securityScheme: 'ApiKey',
    type: 'apiKey',
    name: 'token',
    in: 'header'
)]
final class Server {}
