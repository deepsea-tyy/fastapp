<?php

declare(strict_types=1);


namespace App\Command\Plugin;

use Hyperf\Command\Command;

abstract class AbstractCommand extends Command
{
    protected const COMMAND_NAME = null;

    public function __construct(?string $name = null)
    {
        parent::__construct('plugin:' . static::commandName());
    }

    abstract public function __invoke(): int;

    public static function commandName(): string
    {
        if (static::COMMAND_NAME === null) {
            throw new \RuntimeException('Command name is not defined');
        }
        return static::COMMAND_NAME;
    }
}
