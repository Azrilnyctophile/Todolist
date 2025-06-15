<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'priority',
        'due_date',
        'is_done',
        'user_id',
    ];

    // Relasi Task → User
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
