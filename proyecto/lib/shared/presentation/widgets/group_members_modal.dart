import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/category_management/domain/entities/category.dart';

class GroupMembersModal extends StatelessWidget {
  final GroupEntity group;
  final String currentUsername;
  final VoidCallback? onLeaveGroup;

  const GroupMembersModal({
    Key? key,
    required this.group,
    required this.currentUsername,
    this.onLeaveGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUserInGroup = group.members.contains(currentUsername);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Grupo ${group.groupNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrentUserInGroup && onLeaveGroup != null)
                  ElevatedButton(
                    onPressed: onLeaveGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Salir'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Group info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${group.members.length}/${group.maxMembers} miembros',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Members list
            const Text(
              'Miembros:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: group.members.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay miembros en este grupo',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: group.members.length,
                      itemBuilder: (context, index) {
                        final member = group.members[index];
                        final isCurrentUser = member == currentUsername;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue[50]
                                : Colors.white,
                            border: Border.all(
                              color: isCurrentUser
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isCurrentUser
                                    ? Colors.blue
                                    : Colors.grey[400],
                                child: Text(
                                  member[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  member,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isCurrentUser
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrentUser
                                        ? Colors.blue[800]
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isCurrentUser)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Tú',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
