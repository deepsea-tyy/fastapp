<?php

declare(strict_types=1);

return [
    Hyperf\Database\Commands\Seeders\SeedCommand::class => App\Command\DbSeedCommand::class,
    Hyperf\Cache\Driver\FileSystemDriver::class => App\Common\FileSystemDriver::class,
];
