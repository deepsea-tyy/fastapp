<?php

declare(strict_types=1);


namespace Plugin\Ds\SystemConfig;

class ConfigProvider
{
    public function __invoke()
    {
        return [
            'annotations' => [
                'scan' => [
                    'paths' => [
                        __DIR__,
                    ],
                ],
            ],
            'swagger' => [
                'scan' => [
                    'paths' => [
                        __DIR__ . '/Http/Api',
                    ],
                ],
            ],
        ];
    }
}
