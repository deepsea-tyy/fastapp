<?php

declare(strict_types=1);

namespace Plugin\Ds\Kefu;

use App\Model\Permission\Menu;
use Hyperf\Command\Concerns\InteractsWithIO;

class UninstallScript
{
    use InteractsWithIO;

    public function __construct() {}

    public function __invoke()
    {
        Menu::query()->where('name', 'like', 'kefu%')->delete();
    }
}
