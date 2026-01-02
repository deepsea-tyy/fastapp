<?php
/**
 * FastApp.
 * 1/3/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

declare(strict_types=1);

namespace Plugin\Ds\Ex\Process\CryptoTransfer;

class Ton
{
    /**
     * 格式化TON地址
     * 
     * @param string $address TON地址（可能是hex格式）
     * @return string 格式化后的地址
     */
    public static function addressFormat(string $address): string
    {
        // 如果地址已经是标准格式，直接返回
        if (str_contains($address, ':')) {
            return $address;
        }

        // 处理hex格式的地址
        if (str_starts_with($address, '0x')) {
            $address = substr($address, 2);
        }

        // 如果地址长度足够，提取workchain和hash
        if (strlen($address) >= 66) {
            $workchain = substr($address, 0, 2);
            $hash = substr($address, 2, 64);
            
            // 转换workchain（255表示-1）
            $workchainInt = hexdec($workchain);
            if ($workchainInt === 255) {
                $workchainInt = -1;
            }
            
            return $workchainInt . ':' . $hash;
        }

        return $address;
    }
}

