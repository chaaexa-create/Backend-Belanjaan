<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    protected $fillable = [
        'nama_barang',
        'harga_final',
        'is_dibeli',
    ];

    protected function casts(): array
    {
        return [
            'harga_final' => 'decimal:2',
            'is_dibeli' => 'boolean',
        ];
    }
}
