<?php

declare(strict_types=1);

namespace Plugin\Ds\SysConfig;

use App\Common\Tools;

class ConfigProvider
{
    public function __invoke()
    {
        $basePath = Tools::plugin_path('ds/sysConfig/src');
        
        return [
            'annotations' => [
                'scan' => [
                    'paths' => [
                        $basePath,
                    ],
                ],
            ],
        ];
    }
}
