<?php
/**
 * FastApp.
 * 10/23/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Command\Plugin;

enum PluginTypeEnum: string
{
    case Mix = 'mixed';

    case Frond = 'frond';

    case Backend = 'backend';

    public static function fromValue(string $value): ?self
    {
        return match (mb_strtolower($value)) {
            'mix' => self::Mix,
            'frond' => self::Frond,
            'backend' => self::Backend,
            default => null
        };
    }
}
