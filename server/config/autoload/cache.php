<?php

declare(strict_types=1);

use Hyperf\Cache\Driver\RedisDriver;
use Hyperf\Cache\Driver\FileSystemDriver;
use Hyperf\Codec\Packer\PhpSerializerPacker;

return [
    'default' => [
        'driver' => FileSystemDriver::class,
        'packer' => PhpSerializerPacker::class,
        'prefix' => 'fastapp:',
    ],
];
