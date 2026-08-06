<?php
/**
 * FastApp.
 * 6/24/26
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common;
use Psr\Container\ContainerInterface;
class FileSystemDriver extends \Hyperf\Cache\Driver\FileSystemDriver
{
    protected $storePath;

    public function __construct(ContainerInterface $container, array $config)
    {
        $this->storePath = Tools::runtime_path('caches');

        parent::__construct($container, $config);
    }
}