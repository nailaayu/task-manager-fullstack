package com.example.naila.dto;

import com.example.naila.entity.TaskCategory;
import com.example.naila.entity.TaskStatus;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class TaskRequest {

    @NotBlank(message = "Title wajib diisi")
    private String title;

    private String description;
    private TaskStatus status = TaskStatus.TODO;
    private TaskCategory category;
    private LocalDateTime dueDate;
}
