<?php

declare(strict_types=1);


namespace App\Command\Plugin\Packer;

final class PackerFactory
{
    public function get(string $type = 'json'): PackerInterface
    {
        switch ($type) {
            case 'json':
                return new JsonPacker();
            default:
                throw new \RuntimeException(\sprintf('%s Packer type not found', $type));
        }
    }
}
