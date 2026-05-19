---
title: "EC2, ASG, ALB, EBS, EFS, S3 questions and answers"
description: "EC2    What is EC2? EC2 is a virtual server in AWS used to run applications. What is an..."
published: 2026-02-09
source: "https://dev.to/jumptotech/ec2-asg-alb-ebs-efs-s3-questions-and-answers-gfa"
tags: []
---

# EC2, ASG, ALB, EBS, EFS, S3 questions and answers




#EC2
1. **What is EC2?**
   EC2 is a virtual server in AWS used to run applications.

2. **What is an AMI?**
   A template containing OS, software, and configuration to launch EC2 instances.

3. **Difference between instance type and instance family?**
   Family = category (t, m, c). Type = size (t3.micro).

4. **What happens if you stop an EC2 instance?**
   Instance stops, data on root EBS persists, public IP changes.

5. **What happens if you terminate EC2?**
   Instance is deleted; root volume deleted by default.

6. **Difference between stop and terminate?**
   Stop = reversible. Terminate = permanent.

7. **What is a key pair?**
   SSH authentication method for Linux instances.

8. **How do you connect to EC2?**
   SSH for Linux, RDP for Windows.

9. **What is a security group?**
   Stateful virtual firewall at instance level.

10. **Stateful vs stateless?**
    Security groups are stateful; NACLs are stateless.

11. **What is an Elastic IP?**
    Static public IPv4 address.

12. **When do you need Elastic IP?**
    When IP must not change.

13. **What is user data?**
    Script that runs at instance launch.

14. **Does user data run on reboot?**
    No, only on first launch (unless configured).

15. **Difference between public and private IP?**
    Public = internet access, Private = internal VPC.

16. **What is placement group?**
    Controls how EC2 instances are placed on hardware.

17. **Types of placement groups?**
    Cluster, Spread, Partition.

18. **What is hibernation?**
    Saves RAM state to disk.

19. **Can you change instance type?**
    Yes, stop instance first.

20. **What is EC2 metadata?**
    Instance information accessible internally.

21. **Where is metadata available?**
    [http://169.254.169.254](http://169.254.169.254)

22. **What is ENI?**
    Elastic Network Interface.

23. **Can EC2 have multiple ENIs?**
    Yes (instance-type dependent).

24. **What is Spot instance?**
    Cheap instance with interruption risk.

25. **When to use Spot?**
    Batch jobs, non-critical workloads.

---

## Auto Scaling Group (ASG) 

26. **What is ASG?**
    Automatically manages EC2 count.

27. **Why use ASG?**
    High availability and scalability.

28. **Minimum, desired, maximum?**
    Min = lowest, Desired = normal, Max = highest.

29. **What happens if instance fails?**
    ASG replaces it automatically.

30. **What is a launch template?**
    Blueprint for EC2 in ASG.

31. **Launch template vs launch configuration?**
    Launch configuration is deprecated.

32. **Does ASG need multiple AZs?**
    Yes, for high availability.

33. **What is scaling policy?**
    Rule that increases/decreases instances.

34. **Types of scaling?**
    Manual, Scheduled, Dynamic.

35. **What metrics trigger scaling?**
    CPU, memory (custom), ALB requests.

36. **What is cooldown?**
    Time before next scaling action.

37. **Can ASG scale to zero?**
    Yes (min = 0).

38. **What is health check type?**
    EC2 or ELB health check.

39. **Difference between EC2 and ELB health check?**
    ELB checks application health.

40. **What happens if AZ goes down?**
    ASG launches instances in other AZs.

41. **Can ASG attach to ALB?**
    Yes (recommended).

42. **ASG without ALB?**
    Possible but not ideal.

43. **What happens if you delete instance manually?**
    ASG recreates it.

44. **Can ASG update instances automatically?**
    Yes (rolling updates).

45. **What is instance refresh?**
    Gradual replacement of instances.

---

## ALB (Application Load Balancer) 

46. **What is ALB?**
    Layer 7 load balancer.

47. **ALB vs NLB?**
    ALB = HTTP/HTTPS, NLB = TCP/UDP.

48. **ALB vs Classic LB?**
    Classic is legacy.

49. **What is a target group?**
    Group of backend resources.

50. **Can one ALB have multiple target groups?**
    Yes.

51. **What types of targets are supported?**
    EC2, IP, Lambda.

52. **What is listener?**
    Port/protocol configuration.

53. **Listener rules?**
    Route traffic based on path/host.

54. **Example listener rule?**
    /api → TG1, /app → TG2.

55. **What port does ALB use?**
    80/443 typically.

56. **Is ALB public or private?**
    Can be both.

57. **What is health check path?**
    URL ALB uses to check app health.

58. **What happens if target is unhealthy?**
    ALB stops sending traffic.

59. **Does ALB terminate SSL?**
    Yes.

60. **Where is SSL certificate stored?**
    ACM.

61. **Can ALB redirect HTTP to HTTPS?**
    Yes.

62. **Is ALB stateful?**
    No, stateless.

63. **Does ALB work across AZs?**
    Yes.

64. **Can ALB work with ASG?**
    Yes, automatically registers instances.

65. **Does ALB need security group?**
    Yes.

---

## EBS 

66. **What is EBS?**
    Block storage for EC2.

67. **Is EBS AZ-specific?**
    Yes.

68. **EBS vs instance store?**
    EBS is persistent.

69. **Types of EBS volumes?**
    gp3, io2, st1, sc1.

70. **Can EBS be attached to multiple EC2?**
    No (except io1/io2 Multi-Attach).

71. **What is snapshot?**
    Backup of EBS.

72. **Snapshots stored where?**
    S3 (managed by AWS).

73. **Can you resize EBS?**
    Yes (online).

74. **Can snapshot be copied across regions?**
    Yes.

75. **Root volume delete on terminate?**
    Yes (by default).

---

## EFS 
76. **What is EFS?**
    Managed NFS file system.

77. **EFS vs EBS?**
    EFS = shared, EBS = single instance.

78. **Is EFS AZ-specific?**
    No, regional.

79. **Can multiple EC2 mount EFS?**
    Yes.

80. **What protocol does EFS use?**
    NFS.

81. **Use case for EFS?**
    Shared storage, containers.

82. **Performance modes?**
    General Purpose, Max I/O.

83. **Throughput modes?**
    Bursting, Provisioned.

84. **Is EFS encrypted?**
    Yes (at rest & in transit).

85. **Can EFS be used with ECS/EKS?**
    Yes.

---

## S3 

86. **What is S3?**
    Object storage.

87. **Is S3 regional or global?**
    Regional, globally accessible.

88. **Max object size?**
    5 TB.

89. **Minimum object size?**
    0 bytes.

90. **What is a bucket?**
    Container for objects.

91. **Is bucket name unique?**
    Globally unique.

92. **S3 storage classes?**
    Standard, IA, Glacier, Deep Archive.

93. **What is versioning?**
    Keeps object history.

94. **What is lifecycle policy?**
    Automates storage class transitions.

95. **What is S3 encryption?**
    SSE-S3, SSE-KMS, SSE-C.

96. **S3 vs EBS?**
    Object vs block storage.

97. **S3 vs EFS?**
    Object vs file system.

98. **Can S3 host a website?**
    Yes (static).

99. **Is S3 private by default?**
    Yes.

100. **How do you secure S3?**
     Bucket policy, IAM, encryption.


