<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Admin\Excel;

use App\Common\Excel\AbsImport;

class UserImport extends AbsImport
{

    public function validateRow(array $rowData, int $rowIndex): bool
    {
        return false;
    }

    public function processRow(array $rowData, int $rowIndex): bool
    {
        return true;
    }
}