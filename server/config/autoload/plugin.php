<?php

declare(strict_types=1);

return [

    /*
     * The root directory where the front-end code resides.
     *
     * 前端代码所在根目录.
     */
    'front_directory' => './web/',
    'composer' => [
        /*
         * composer executes the program directly from composer by default,
         * but if there is an environment restriction,
         * you can specify something like /usr/bin/composer.
         *
         *
         * composer 执行程序 默认直接是 composer 如果有环境限制 可以指定比如 /usr/bin/composer
         */
        'bin' => 'composer',
    ],
    'front-tool' => [
        /*
         * Front-end package management execution tools Optional npm yarn pnpm, default npm is used
         *
         *
         * 前端包管理执行工具 可选 npm yarn pnpm，默认使用 npm
         */
        'type' => 'pnpm',
        /*
         * The default directory for executing programs is npm,
         * but if you don't have the npm environment variable configured,
         * you can manually specify the program to execute, e.g. /usr/local/npm/bin/npm.
         *
         *
         * 执行程序所在目录 默认是直接执行 npm, 如果没有配置 npm 环境变量 则可以手动指定 执行程序 例如 /usr/local/npm/bin/npm
         */
        'bin' => 'npm',
    ],
];

