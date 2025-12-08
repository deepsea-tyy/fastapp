<?php

declare(strict_types=1);


namespace Plugin\Ds\SysCms;

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
                    ],
                ],
            ],
        ];
    }
}
