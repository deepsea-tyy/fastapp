<?php
/**
 * FastApp.
 * 12/25/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace Plugin\Ds\SysCms\Event;

class ArticleEvent
{
    public function __construct(public int $id, public array $categoryIds = [])
    {
    }
}