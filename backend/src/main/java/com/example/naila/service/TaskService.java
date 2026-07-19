package com.example.naila.service;

import com.example.naila.dto.TaskRequest;
import com.example.naila.dto.TaskResponse;
import com.example.naila.entity.Task;
import com.example.naila.entity.TaskCategory;
import com.example.naila.entity.TaskStatus;
import com.example.naila.entity.User;
import com.example.naila.exception.ResourceNotFoundException;
import com.example.naila.repository.TaskRepository;
import com.example.naila.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    public List<TaskResponse> getUserTasks(String username) {
        return taskRepository.findByUserUsernameOrderByCreatedAtDesc(username)
                .stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    public TaskResponse getTaskById(Long id, String username) {
        Task task = getTaskOwnedByUser(id, username);
        return TaskResponse.fromEntity(task);
    }

    @Transactional
    public TaskResponse createTask(TaskRequest request, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User tidak ditemukan"));

        Task task = Task.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .status(request.getStatus() == null ? TaskStatus.TODO : request.getStatus())
                .category(request.getCategory())
                .dueDate(request.getDueDate())
                .user(user)
                .build();

        Task savedTask = taskRepository.save(task);
        return TaskResponse.fromEntity(savedTask);
    }

    @Transactional
    public TaskResponse updateTask(Long id, TaskRequest request, String username) {
        Task task = getTaskOwnedByUser(id, username);
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus() == null ? TaskStatus.TODO : request.getStatus());
        task.setCategory(request.getCategory());
        task.setDueDate(request.getDueDate());
        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    @Transactional
    public TaskResponse updateTaskStatus(Long id, TaskStatus status, String username) {
        Task task = getTaskOwnedByUser(id, username);
        task.setStatus(status);
        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    @Transactional
    public void deleteTask(Long id, String username) {
        Task task = getTaskOwnedByUser(id, username);
        taskRepository.delete(task);
    }

    public List<TaskResponse> searchTasks(String query, String username) {
        return taskRepository.findByUserUsernameAndTitleContainingIgnoreCaseOrderByCreatedAtDesc(username, query)
                .stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    public List<TaskResponse> filterTasksByStatus(TaskStatus status, String username) {
        return taskRepository.findByUserUsernameAndStatusOrderByCreatedAtDesc(username, status)
                .stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    public List<TaskResponse> filterTasksByCategory(TaskCategory category, String username) {
        return taskRepository.findByUserUsernameAndCategoryOrderByCreatedAtDesc(username, category)
                .stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    private Task getTaskOwnedByUser(Long id, String username) {
        return taskRepository.findByIdAndUserUsername(id, username)
                .orElseThrow(() -> new ResourceNotFoundException("Task tidak ditemukan"));
    }
}
