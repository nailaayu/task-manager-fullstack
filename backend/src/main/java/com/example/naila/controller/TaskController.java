package com.example.naila.controller;

import com.example.naila.dto.TaskRequest;
import com.example.naila.dto.TaskResponse;
import com.example.naila.entity.TaskCategory;
import com.example.naila.entity.TaskStatus;
import com.example.naila.service.TaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    public ResponseEntity<List<TaskResponse>> getAllTasks(Authentication authentication) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.getUserTasks(username));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaskResponse> getTaskById(@PathVariable Long id, Authentication authentication) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.getTaskById(id, username));
    }

    @PostMapping
    public ResponseEntity<TaskResponse> createTask(
            @Valid @RequestBody TaskRequest request,
            Authentication authentication
    ) {
        String username = authentication.getName();
        TaskResponse task = taskService.createTask(request, username);
        return ResponseEntity.status(201).body(task);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable Long id,
            @Valid @RequestBody TaskRequest request,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.updateTask(id, request, username));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<TaskResponse> updateTaskStatus(
            @PathVariable Long id,
            @RequestParam TaskStatus status,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.updateTaskStatus(id, status, username));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteTask(@PathVariable Long id, Authentication authentication) {
        String username = authentication.getName();
        taskService.deleteTask(id, username);
        return ResponseEntity.ok(Map.of("message", "Task deleted successfully"));
    }

    @GetMapping("/search")
    public ResponseEntity<List<TaskResponse>> searchTasks(
            @RequestParam String query,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.searchTasks(query, username));
    }

    @GetMapping("/filter/status")
    public ResponseEntity<List<TaskResponse>> filterByStatus(
            @RequestParam TaskStatus status,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.filterTasksByStatus(status, username));
    }

    @GetMapping("/filter/category")
    public ResponseEntity<List<TaskResponse>> filterByCategory(
            @RequestParam TaskCategory category,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(taskService.filterTasksByCategory(category, username));
    }
}
