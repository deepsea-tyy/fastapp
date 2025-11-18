<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Admin\Excel;

use App\Common\Excel\AbsExport;

class UserExport extends AbsExport
{

    protected function preprocessData(array $data): array
    {
        return $data;
    }

    protected function preprocessHeaders(array $headers): array
    {
        return $headers;
    }
}