<?php

declare(strict_types=1);

namespace App\Command;

use Hyperf\Database\Commands\Seeders\SeedCommand;

final class DbSeedCommand extends SeedCommand
{
    protected function getSeederPaths(): array
    {
        if ($this->input->getOption('path')) {
            return [$this->getSeederPath()];
        }

        return parent::getSeederPaths();
    }
}
