<?php

declare(strict_types=1);


namespace App\Command\Plugin;

class PluginNotFoundException extends \Exception
{
    public function __construct($path)
    {
        parent::__construct(\sprintf('The given directory [%s] is not a valid plugin, probably because it is already installed or the directory is not standardized.', $path));
    }
}
