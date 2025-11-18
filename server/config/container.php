<?php

/**
 * Initialize a dependency injection container that implemented PSR-11 and return the container.
 */

declare(strict_types=1);

use App\Command\Plugin\Plugin;
use Hyperf\Context\ApplicationContext;
use Hyperf\Di\Container;
use Hyperf\Di\Definition\DefinitionSource;

$configFromProviders = Plugin::loadProviderConfig();
$serverDependencies = $configFromProviders['dependencies'] ?? [];
$dependenciesPath = BASE_PATH . '/config/autoload/dependencies.php';
if (file_exists($dependenciesPath)) {
    $definitions = include $dependenciesPath;
    $serverDependencies = array_replace($serverDependencies, $definitions ?? []);
}

return ApplicationContext::setContainer(new Container(new DefinitionSource($serverDependencies)));
