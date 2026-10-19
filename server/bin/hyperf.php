#!/usr/bin/env php
<?php

declare(strict_types=1);

use Hyperf\Contract\ApplicationInterface;
use Hyperf\Di\ClassLoader;
use Hyperf\Engine\DefaultOption;
use Psr\Container\ContainerInterface;
use App\Command\Plugin\Plugin;

ini_set('display_errors', 'on');
ini_set('display_startup_errors', 'on');
ini_set('memory_limit', '1G');

error_reporting(E_ALL);
date_default_timezone_set('Asia/Shanghai');
! defined('BASE_PATH') && define('BASE_PATH', dirname(__DIR__, 1));
! defined('HF_VERSION') && define('HF_VERSION', '3.1');     // 定义hyperf版本号

require BASE_PATH . '/vendor/autoload.php';

! defined('SWOOLE_HOOK_FLAGS') && define('SWOOLE_HOOK_FLAGS', DefaultOption::hookFlags());
// Self-called anonymous function that creates its own scope and keep the global namespace clean.
(function () {
    Plugin::init();
    ClassLoader::init();

    if (\Phar::running(false)) {
        Plugin::scanAnnotations();
    }

    /** @var ContainerInterface $container */
    $container = require BASE_PATH . '/config/container.php';

    $application = $container->get(ApplicationInterface::class);
    $application->run();
})();