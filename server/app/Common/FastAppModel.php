<?php
/**
 * FastApp.
 * 6/22/26
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common;

use Hyperf\DbConnection\Model\Model;

class FastAppModel extends Model
{
    public function formatData(array $data): array
    {
        foreach ($this->getCasts() as $field => $rule) {
            if (array_key_exists($field, $data)) $data[$field] = match ($rule) {
                'integer' => (int)$data[$field],
                'float' => (float)$data[$field],
                'string' => (string)$data[$field],
                default => $data[$field],
            };
        }
        return $data;
    }
}