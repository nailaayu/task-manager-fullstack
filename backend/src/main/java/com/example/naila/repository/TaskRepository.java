package com.example.naila.repository;

import com.example.naila.entity.Task;
import com.example.naila.entity.TaskCategory;
import com.example.naila.entity.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByUserUsernameOrderByCreatedAtDesc(String username);
    Optional<Task> findByIdAndUserUsername(Long id, String username);
    List<Task> findByUserUsernameAndStatusOrderByCreatedAtDesc(String username, TaskStatus status);
    List<Task> findByUserUsernameAndCategoryOrderByCreatedAtDesc(String username, TaskCategory category);
    List<Task> findByUserUsernameAndTitleContainingIgnoreCaseOrderByCreatedAtDesc(String username, String title);
}
