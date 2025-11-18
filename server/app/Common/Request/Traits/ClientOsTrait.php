<?php
/**
 * FastApp.
 * 10/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Request\Traits;

trait ClientOsTrait
{
    public function os(): string
    {
        $userAgent = $this->header('user-agent');
        if (empty($userAgent)) {
            return 'Unknown';
        }
        return match (true) {
            preg_match('/win/i', $userAgent) => 'Windows',
            preg_match('/mac/i', $userAgent) => 'MAC',
            preg_match('/linux/i', $userAgent) => 'Linux',
            preg_match('/unix/i', $userAgent) => 'Unix',
            preg_match('/bsd/i', $userAgent) => 'BSD',
            default => 'Other',
        };
    }
}