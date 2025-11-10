<?php

declare(strict_types=1);


namespace App\Command\Plugin\Packer;

interface PackerInterface
{
    public function unpack(string $body): array;

    public function pack(array $body): string;
}
