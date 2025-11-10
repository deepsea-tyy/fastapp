<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Excel;

use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

/**
 * 通用Excel导出抽象类
 * $export = new UserExport();
        $export->setSavePath(BASE_PATH . '/storage')
            ->setHeaders(['一','二','xx','bb'])
            ->setData([[1,2,3,4]]);
       $file = $export->setChunkSize(1000) // 设置分片大小
        ->generateChunked();
 */
abstract class AbsExport
{
    /**
     * @var Spreadsheet Excel对象
     */
    protected Spreadsheet $spreadsheet;

    /**
     * @var array 导出数据
     */
    protected array $exportData = [];

    /**
     * @var array 表头数据
     */
    protected array $headers = [];

    /**
     * @var array 错误信息
     */
    protected array $errors = [];

    /**
     * @var string 文件名
     */
    protected string $filename = 'export';

    /**
     * @var string 工作表名称
     */
    protected string $sheetName = 'Sheet1';

    /**
     * @var bool 是否自动设置表头样式
     */
    protected bool $autoHeaderStyle = true;

    /**
     * @var int 分片大小（每次处理的数据行数）
     */
    protected int $chunkSize = 1000;

    /**
     * @var int 当前分片起始索引
     */
    protected int $currentChunkStart = 0;

    /**
     * @var bool 是否已处理完所有数据
     */
    protected bool $isFinished = false;

    /**
     * @var string 文件保存路径
     */
    protected string $savePath = '';

    /**
     * 构造函数
     */
    public function __construct()
    {
        $this->spreadsheet = new Spreadsheet();
        $this->spreadsheet->setActiveSheetIndex(0);
        $this->spreadsheet->getActiveSheet()->setTitle($this->sheetName);
        $this->savePath = sys_get_temp_dir();
    }

    /**
     * 设置导出数据
     *
     * @param array $data
     * @return self
     */
    public function setData(array $data): self
    {
        $this->exportData = $data;
        return $this;
    }

    /**
     * 设置表头数据
     *
     * @param array $headers
     * @return self
     */
    public function setHeaders(array $headers): self
    {
        $this->headers = $headers;
        return $this;
    }

    /**
     * 设置文件名
     *
     * @param string $filename
     * @return self
     */
    public function setFilename(string $filename): self
    {
        $this->filename = $filename;
        return $this;
    }

    /**
     * 设置工作表名称
     *
     * @param string $sheetName
     * @return self
     */
    public function setSheetName(string $sheetName): self
    {
        $this->sheetName = $sheetName;
        $this->spreadsheet->getActiveSheet()->setTitle($sheetName);
        return $this;
    }

    /**
     * 设置是否自动应用表头样式
     *
     * @param bool $autoHeaderStyle
     * @return self
     */
    public function setAutoHeaderStyle(bool $autoHeaderStyle): self
    {
        $this->autoHeaderStyle = $autoHeaderStyle;
        return $this;
    }

    /**
     * 设置分片大小
     *
     * @param int $chunkSize
     * @return self
     */
    public function setChunkSize(int $chunkSize): self
    {
        $this->chunkSize = max(1, $chunkSize);
        return $this;
    }

    /**
     * 设置文件保存路径
     *
     * @param string $path
     * @return self
     */
    public function setSavePath(string $path): self
    {
        if (!is_dir($path)) {
            if (!mkdir($path, 0755, true)) {
                throw new \RuntimeException("无法创建目录: {$path}");
            }
        }

        if (!is_writable($path)) {
            throw new \RuntimeException("目录不可写: {$path}");
        }

        $this->savePath = rtrim($path, DIRECTORY_SEPARATOR);
        return $this;
    }

    /**
     * 生成Excel文件
     *
     * @return string 文件路径
     */
    public function generate(): string
    {
        try {
            $worksheet = $this->spreadsheet->getActiveSheet();
            $currentRow = 1;

            // 写入表头
            if (!empty($this->headers)) {
                $this->writeHeaders($worksheet, $currentRow);
                $currentRow++;
            }

            // 写入数据
            $this->writeData($worksheet, $currentRow);

            // 自动调整列宽
            $this->autoSizeColumns($worksheet);

            return $this->saveFile();
        } catch (\Exception $e) {
            $this->errors[] = "生成Excel文件失败: " . $e->getMessage();
            throw $e;
        }
    }

    /**
     * 分片生成Excel文件（适合大数据量）
     *
     * @return string 文件路径
     */
    public function generateChunked(): string
    {
        $this->resetChunk();

        try {
            $worksheet = $this->spreadsheet->getActiveSheet();
            $currentRow = 1;

            // 写入表头
            if (!empty($this->headers)) {
                $this->writeHeaders($worksheet, $currentRow);
                $currentRow++;
            }

            // 分片写入数据
            while ($this->hasMoreData()) {
                $chunkData = $this->getCurrentChunk();
                $this->appendDataToWorksheet($worksheet, $chunkData, $currentRow);
                $currentRow += count($chunkData);
                $this->currentChunkStart += $this->chunkSize;
            }

            // 自动调整列宽
            $this->autoSizeColumns($worksheet);

            return $this->saveFile();
        } catch (\Exception $e) {
            $this->errors[] = "分片生成Excel文件失败: " . $e->getMessage();
            throw $e;
        }
    }

    /**
     * 写入表头
     *
     * @param Worksheet $worksheet
     * @param int $startRow
     */
    protected function writeHeaders(Worksheet $worksheet, int $startRow): void
    {
        $col = 1;
        foreach ($this->headers as $header) {
            $cellCoordinate = Coordinate::stringFromColumnIndex($col) . $startRow;
            $worksheet->setCellValue($cellCoordinate, $header);

            if ($this->autoHeaderStyle) {
                $this->applyHeaderStyle($worksheet, $cellCoordinate);
            }

            $col++;
        }
    }

    /**
     * 写入数据
     *
     * @param Worksheet $worksheet
     * @param int $startRow
     */
    protected function writeData(Worksheet $worksheet, int $startRow): void
    {
        $currentRow = $startRow;

        foreach ($this->exportData as $rowData) {
            $col = 1;
            foreach ($rowData as $cellValue) {
                $cellCoordinate = Coordinate::stringFromColumnIndex($col) . $currentRow;
                $worksheet->setCellValue($cellCoordinate, $cellValue);
                $col++;
            }
            $currentRow++;
        }
    }


    /**
     * 追加数据到工作表
     *
     * @param Worksheet $worksheet
     * @param array $data
     * @param int $startRow
     */
    protected function appendDataToWorksheet(Worksheet $worksheet, array $data, int $startRow): void
    {
        $currentRow = $startRow;
        foreach ($data as $rowData) {
            $col = 1;
            foreach ($rowData as $cellValue) {
                $cellCoordinate = Coordinate::stringFromColumnIndex($col) . $currentRow;
                $worksheet->setCellValue($cellCoordinate, $cellValue);
                $col++;
            }
            $currentRow++;
        }
    }

    /**
     * 应用表头样式
     *
     * @param Worksheet $worksheet
     * @param string $cellCoordinate
     */
    protected function applyHeaderStyle(Worksheet $worksheet, string $cellCoordinate): void
    {
        $style = $worksheet->getStyle($cellCoordinate);

        // 设置字体样式
        $style->getFont()->setBold(true);
        $style->getFont()->setSize(12);

        // 设置背景颜色
        $style->getFill()->setFillType(Fill::FILL_SOLID);
        $style->getFill()->getStartColor()->setRGB('D9D9D9');

        // 设置对齐方式
        $style->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $style->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);

        // 设置边框
        $style->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
    }

    /**
     * 自动调整列宽
     *
     * @param Worksheet $worksheet
     */
    protected function autoSizeColumns(Worksheet $worksheet): void
    {
        $highestColumn = $worksheet->getHighestColumn();
        $highestColumnIndex = Coordinate::columnIndexFromString($highestColumn);

        for ($col = 1; $col <= $highestColumnIndex; $col++) {
            $columnLetter = Coordinate::stringFromColumnIndex($col);
            $worksheet->getColumnDimension($columnLetter)->setAutoSize(true);
        }
    }

    /**
     * 保存文件
     *
     * @return string
     */
    protected function saveFile(): string
    {
        $filename = $this->filename . '_' . date('YmdHis') . '.xlsx';
        $filePath = $this->savePath . DIRECTORY_SEPARATOR . $filename;

        $writer = new Xlsx($this->spreadsheet);
        $writer->save($filePath);

        return $filePath;
    }

    /**
     * 获取错误信息
     *
     * @return array
     */
    public function getErrors(): array
    {
        return $this->errors;
    }

    /**
     * 获取当前分片数据
     *
     * @return array
     */
    protected function getCurrentChunk(): array
    {
        return array_slice($this->exportData, $this->currentChunkStart, $this->chunkSize);
    }

    /**
     * 检查是否还有更多数据
     *
     * @return bool
     */
    public function hasMoreData(): bool
    {
        return !$this->isFinished && $this->currentChunkStart < count($this->exportData);
    }

    /**
     * 重置分片状态
     *
     * @return self
     */
    public function resetChunk(): self
    {
        $this->currentChunkStart = 0;
        $this->isFinished = false;
        return $this;
    }

    /**
     * 获取导出统计信息
     *
     * @return array
     */
    public function getStatistics(): array
    {
        return [
            'total_rows' => count($this->exportData),
            'header_count' => count($this->headers),
            'filename' => $this->filename,
            'sheet_name' => $this->sheetName,
            'chunk_size' => $this->chunkSize,
            'current_chunk_start' => $this->currentChunkStart,
            'is_finished' => $this->isFinished
        ];
    }

    /**
     * 数据预处理（抽象方法，子类可选择性实现）
     *
     * @param array $data
     * @return array
     */
    abstract protected function preprocessData(array $data): array;

    /**
     * 表头预处理（抽象方法，子类可选择性实现）
     *
     * @param array $headers
     * @return array
     */
    abstract protected function preprocessHeaders(array $headers): array;
}