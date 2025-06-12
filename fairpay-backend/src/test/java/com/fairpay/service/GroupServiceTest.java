package com.fairpay.service;

import com.fairpay.dto.GroupRequestDTO;
import com.fairpay.model.Group;
import com.fairpay.model.User;
import com.fairpay.repository.GroupRepository;
import com.fairpay.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class GroupServiceTest {

    @Mock
    private GroupRepository groupRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private GroupService groupService;

    private User testUser;
    private GroupRequestDTO validRequest;

    @BeforeEach
    void setUp() {
        // Configurar usuário de teste
        testUser = new User();
        testUser.setId(1L);
        testUser.setName("Usuário Teste");
        
        // Configurar DTO válido para criação de grupo
        validRequest = new GroupRequestDTO();
        validRequest.setName("Viagem para o Rio");
        validRequest.setDescription("Grupo para dividir despesas da viagem de final de semana");
        validRequest.setImageUrl("https://example.com/imagem.png");
        
        // Removido o stub daqui, será colocado em cada teste específico
    }

    @Test
    void createGroup_WithValidData_ShouldCreateGroup() {
        // Arrange
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser)); // Movido para cá
        
        Group savedGroup = new Group();
        savedGroup.setId(42L);
        savedGroup.setName(validRequest.getName());
        savedGroup.setDescription(validRequest.getDescription());
        savedGroup.setImageUrl(validRequest.getImageUrl());
        savedGroup.setCreatedBy(testUser);
        savedGroup.setCreatedAt(Instant.now());
        
        when(groupRepository.save(any(Group.class))).thenReturn(savedGroup);

        // Act
        Group result = groupService.createGroup(validRequest, 1L);

        // Assert
        assertNotNull(result);
        assertEquals(42L, result.getId());
        assertEquals("Viagem para o Rio", result.getName());
        assertEquals("Grupo para dividir despesas da viagem de final de semana", result.getDescription());
        assertEquals("https://example.com/imagem.png", result.getImageUrl());
        assertEquals(testUser, result.getCreatedBy());
        assertNotNull(result.getCreatedAt());
        
        // Verificar se o repositório foi chamado corretamente
        verify(groupRepository, times(1)).save(any(Group.class));
        
        // Capturar e verificar o objeto Group passado para o repository
        ArgumentCaptor<Group> groupCaptor = ArgumentCaptor.forClass(Group.class);
        verify(groupRepository).save(groupCaptor.capture());
        Group capturedGroup = groupCaptor.getValue();
        
        assertEquals(validRequest.getName(), capturedGroup.getName());
        assertEquals(validRequest.getDescription(), capturedGroup.getDescription());
        assertEquals(validRequest.getImageUrl(), capturedGroup.getImageUrl());
        assertEquals(testUser, capturedGroup.getCreatedBy());
    }

    @Test
    void createGroup_WithEmptyName_ShouldThrowException() {
        // Arrange
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser)); // Movido para cá
        
        GroupRequestDTO invalidRequest = new GroupRequestDTO();
        invalidRequest.setName(""); // Nome vazio
        invalidRequest.setDescription("Descrição teste");

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            groupService.createGroup(invalidRequest, 1L);
        });
        
        assertEquals("O nome do grupo não pode ser vazio.", exception.getMessage());
        verify(groupRepository, never()).save(any(Group.class));
    }
    
    @Test
    void createGroup_WithNullName_ShouldThrowException() {
        // Arrange
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser)); // Movido para cá
        
        GroupRequestDTO invalidRequest = new GroupRequestDTO();
        invalidRequest.setName(null); // Nome nulo
        invalidRequest.setDescription("Descrição teste");

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            groupService.createGroup(invalidRequest, 1L);
        });
        
        assertEquals("O nome do grupo não pode ser vazio.", exception.getMessage());
        verify(groupRepository, never()).save(any(Group.class));
    }
    
    @Test
    void createGroup_WithInvalidUserId_ShouldThrowException() {
        // Arrange
        when(userRepository.findById(999L)).thenReturn(Optional.empty()); // ID específico para este teste

        // Act & Assert
        EntityNotFoundException exception = assertThrows(EntityNotFoundException.class, () -> {
            groupService.createGroup(validRequest, 999L);
        });
        
        assertEquals("Usuário não encontrado", exception.getMessage());
        verify(groupRepository, never()).save(any(Group.class));
    }
}